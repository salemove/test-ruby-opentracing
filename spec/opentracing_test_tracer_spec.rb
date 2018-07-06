# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OpenTracingTestTracer do
  let(:tracer) { described_class.build }

  describe '#start_span' do
    let(:operation_name) { 'operator-name' }

    context 'when a root span' do
      let(:span) { tracer.start_span(operation_name) }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([span])
      end
    end

    context 'when a child_of span context is provided' do
      let(:root_span) { tracer.start_span(root_operation_name) }
      let(:span) { tracer.start_span(operation_name, child_of: root_span.context) }
      let(:root_operation_name) { 'root-operation-name' }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).not_to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([root_span, span])
      end
    end

    context 'when a child_of span is provided' do
      let(:root_span) { tracer.start_span(root_operation_name) }
      let(:span) { tracer.start_span(operation_name, child_of: root_span) }
      let(:root_operation_name) { 'root-operation-name' }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).not_to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([root_span, span])
      end
    end

    context 'when a parent context is provided using references' do
      let(:root_span) { tracer.start_span(root_operation_name) }
      let(:span) { tracer.start_span(operation_name, references: references) }
      let(:references) { [OpenTracing::Reference.child_of(root_span.context)] }
      let(:root_operation_name) { 'root-operation-name' }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).not_to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([root_span, span])
      end
    end
  end

  describe '#start_active_span' do
    let(:operation_name) { 'operator-name' }

    context 'when a root span' do
      let(:scope) { tracer.start_active_span(operation_name) }
      let(:span) { scope.span }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([span])
      end
    end

    context 'when a child_of span context is provided' do
      let(:root_span) { tracer.start_span(root_operation_name) }
      let(:scope) { tracer.start_active_span(operation_name, child_of: root_span.context) }
      let(:span) { scope.span }
      let(:root_operation_name) { 'root-operation-name' }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).not_to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([root_span, span])
      end
    end

    context 'when a child_of span is provided' do
      let(:root_span) { tracer.start_span(root_operation_name) }
      let(:scope) { tracer.start_active_span(operation_name, child_of: root_span) }
      let(:span) { scope.span }
      let(:root_operation_name) { 'root-operation-name' }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).not_to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([root_span, span])
      end
    end

    context 'when a parent context is provided using references' do
      let(:root_span) { tracer.start_span(root_operation_name) }
      let(:scope) { tracer.start_active_span(operation_name, references: references) }
      let(:span) { scope.span }
      let(:references) { [OpenTracing::Reference.child_of(root_span.context)] }
      let(:root_operation_name) { 'root-operation-name' }

      describe 'span context' do
        it 'has span_id' do
          expect(span.context.span_id).not_to be_nil
        end

        it 'has trace_id' do
          expect(span.context.trace_id).not_to be_nil
        end

        it 'does not have parent_id' do
          expect(span.context.parent_id).not_to be_nil
        end
      end

      it 'records the span' do
        expect(tracer.spans).to eq([root_span, span])
      end
    end

    context 'when already existing active span' do
      let(:root_operation_name) { 'root-operation-name' }

      it 'uses active span as a parent span' do
        tracer.start_active_span(root_operation_name) do |parent_scope|
          tracer.start_active_span(operation_name) do |scope|
            expect(scope.span.context.parent_id).to eq(parent_scope.span.context.span_id)
          end
        end
      end
    end
  end

  describe '#active_span' do
    let(:root_operation_name) { 'root-operation-name' }
    let(:operation_name) { 'operation-name' }

    it 'returns the span of the active scope' do
      expect(tracer.active_span).to eq(nil)

      tracer.start_active_span(root_operation_name) do |parent_scope|
        expect(tracer.active_span).to eq(parent_scope.span)

        tracer.start_active_span(operation_name) do |scope|
          expect(tracer.active_span).to eq(scope.span)
        end

        expect(tracer.active_span).to eq(parent_scope.span)
      end

      expect(tracer.active_span).to eq(nil)
    end
  end

  describe '#inject' do
    let(:span_context) do
      OpenTracingTestTracer::SpanContext.new(
        trace_id: trace_id,
        parent_id: parent_id,
        span_id: span_id
      )
    end
    let(:trace_id) { 'trace-id' }
    let(:parent_id) { 'trace-id' }
    let(:span_id) { 'trace-id' }
    let(:carrier) { {} }

    context 'when FORMAT_TEXT_MAP' do
      before { tracer.inject(span_context, OpenTracing::FORMAT_TEXT_MAP, carrier) }

      it 'sets trace-id' do
        expect(carrier['test-traceid']).to eq(trace_id)
      end

      it 'sets parent-id' do
        expect(carrier['test-parentspanid']).to eq(parent_id)
      end

      it 'sets span-id' do
        expect(carrier['test-spanid']).to eq(span_id)
      end
    end

    context 'when FORMAT_RACK' do
      before { tracer.inject(span_context, OpenTracing::FORMAT_RACK, carrier) }

      it 'sets test-traceid' do
        expect(carrier['test-traceid']).to eq(trace_id)
      end

      it 'sets test-parentspanid' do
        expect(carrier['test-parentspanid']).to eq(parent_id)
      end

      it 'sets test-spanid' do
        expect(carrier['test-spanid']).to eq(span_id)
      end
    end
  end

  describe '#extract' do
    let(:operation_name) { 'operator-name' }
    let(:trace_id) { 'trace-id' }
    let(:parent_id) { 'parent-id' }
    let(:span_id) { 'span-id' }

    context 'when FORMAT_TEXT_MAP' do
      let(:carrier) do
        {
          'test-traceid' => trace_id,
          'test-parentspanid' => parent_id,
          'test-spanid' => span_id
        }
      end
      let(:span_context) { tracer.extract(OpenTracing::FORMAT_TEXT_MAP, carrier) }

      it 'has trace id' do
        expect(span_context.trace_id).to eq(trace_id)
      end

      it 'has parent id' do
        expect(span_context.parent_id).to eq(parent_id)
      end

      it 'has span id' do
        expect(span_context.span_id).to eq(span_id)
      end

      context 'when trace-id is missing' do
        let(:trace_id) { nil }

        it 'returns nil' do
          expect(span_context).to eq(nil)
        end
      end

      context 'when span-id is missing' do
        let(:span_id) { nil }

        it 'returns nil' do
          expect(span_context).to eq(nil)
        end
      end
    end

    context 'when FORMAT_RACK' do
      let(:carrier) do
        {
          'HTTP_TEST_TRACEID' => trace_id,
          'HTTP_TEST_PARENTSPANID' => parent_id,
          'HTTP_TEST_SPANID' => span_id
        }
      end
      let(:span_context) { tracer.extract(OpenTracing::FORMAT_RACK, carrier) }

      it 'has trace id' do
        expect(span_context.trace_id).to eq(trace_id)
      end

      it 'has parent id' do
        expect(span_context.parent_id).to eq(parent_id)
      end

      it 'has span id' do
        expect(span_context.span_id).to eq(span_id)
      end

      context 'when TEST-TraceId is missing' do
        let(:trace_id) { nil }

        it 'returns nil' do
          expect(span_context).to eq(nil)
        end
      end

      context 'when TEST-SpanId is missing' do
        let(:span_id) { nil }

        it 'returns nil' do
          expect(span_context).to eq(nil)
        end
      end
    end
  end
end
